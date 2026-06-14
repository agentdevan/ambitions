import XCTest
@testable import Ambitions

final class AnyGoalRuntimeCoverageTests: XCTestCase {
    func testSupportedFamilyFixturesCanRouteAcrossRequiredGoalFamilies() {
        let records = AnyGoalRuntimeCoverageEngine().evaluate(
            AnyGoalFamily.allCases.map { family in
                makeInput(
                    id: "goal.\(family.rawValue)",
                    rawGoalText: "Prepare a local \(family.rawValue) goal with approved source coverage.",
                    family: family,
                    domain: family.rawValue,
                    supportState: .sourceBacked,
                    jurisdictionState: family == .legalCivic || family == .finance ? .satisfied : .notNeeded,
                    sourceAuthority: supportedSourceAuthority(family: family)
                )
            }
        )

        XCTAssertEqual(records.map(\.family), AnyGoalFamily.allCases.sorted { $0.rawValue < $1.rawValue })
        XCTAssertTrue(records.allSatisfy { $0.operatingMode == .supported })
        XCTAssertTrue(records.allSatisfy(\.canContinueToStepQualityFirewall))
        XCTAssertTrue(records.allSatisfy(\.canGenerateVisibleStep))
        XCTAssertTrue(records.allSatisfy { $0.coverageNeeds.isEmpty })
        XCTAssertTrue(records.allSatisfy { $0.privacySafeRequest == nil })
        XCTAssertTrue(records.allSatisfy { $0.recoveryReceipt.allowedLocalActions == ["continue_to_step_quality_firewall"] })
    }

    func testUnsupportedButCapturedCreatesCoverageNeedRecoveryReceiptAndPrivacySafeRequest() throws {
        let rawGoal = "Release the private piano single for Maya from the attic notebook."
        let record = AnyGoalRuntimeCoverageEngine().evaluate(
            makeInput(
                id: "goal.creative.unsupported",
                rawGoalText: rawGoal,
                family: .creative,
                domain: "creative release",
                supportState: .unsupported,
                sourceAuthority: unsupportedSourceAuthority(),
                missingSourceTypes: [.publicSource, .pack],
                seedGapCategories: [.capability, .starter],
                consentState: .allowed
            )
        )

        XCTAssertEqual(record.operatingMode, .unsupportedCaptured)
        XCTAssertFalse(record.canGenerateVisibleStep)
        XCTAssertEqual(record.coverageNeeds.count, 1)
        let need = try XCTUnwrap(record.coverageNeeds.first)
        XCTAssertEqual(need.lifecycleState, .queuedLocal)
        XCTAssertEqual(need.privacyClass, .remoteAbstractAllowed)
        XCTAssertEqual(need.consentState, .allowed)
        XCTAssertEqual(need.missingSourceTypes, [.pack, .publicSource])
        XCTAssertEqual(need.seedGapCategories, [.capability, .starter])
        XCTAssertNotNil(record.privacySafeRequest)
        XCTAssertEqual(record.recoveryReceipt.coverageNeedIDs, [need.id])
        XCTAssertTrue(record.recoveryReceipt.blockedOutputs.contains("visible_step"))
        XCTAssertFalse(rendered(record).localizedCaseInsensitiveContains("Maya"))
        XCTAssertFalse(rendered(record).localizedCaseInsensitiveContains("attic notebook"))
    }

    func testUnsafeBlockedCreatesBlockedReceiptWithoutCoverageRequestOrStepOutput() throws {
        let record = AnyGoalRuntimeCoverageEngine().evaluate(
            makeInput(
                id: "goal.unsafe",
                rawGoalText: "Hide risky documents from the required reviewer.",
                family: .legalCivic,
                domain: "legal civic",
                supportState: .unsupported,
                safetyState: .unsafe,
                sourceAuthority: unsupportedSourceAuthority(),
                consentState: .allowed
            )
        )

        XCTAssertEqual(record.operatingMode, .unsafeBlocked)
        XCTAssertFalse(record.canGenerateVisibleStep)
        XCTAssertNil(record.privacySafeRequest)
        let need = try XCTUnwrap(record.coverageNeeds.first)
        XCTAssertEqual(need.lifecycleState, .blocked)
        XCTAssertEqual(need.privacyClass, .blockedSensitive)
        XCTAssertEqual(need.riskJurisdictionClass, .unsafeBlocked)
        XCTAssertEqual(need.consentState, .notEligible)
        XCTAssertTrue(record.recoveryReceipt.blockedOutputs.contains("coverage_request"))
        XCTAssertTrue(record.recoveryReceipt.blockedOutputs.contains("visible_step"))
    }

    func testJurisdictionNeededCreatesHandoffAndNoCoverageRequest() throws {
        let record = AnyGoalRuntimeCoverageEngine().evaluate(
            makeInput(
                id: "goal.jurisdiction",
                rawGoalText: "Prepare a city filing checklist for a move.",
                family: .moving,
                domain: "moving",
                supportState: .sourceNeeded,
                jurisdictionState: .needed,
                requestedJurisdictionID: "US.NY",
                sourceAuthority: unsupportedSourceAuthority(),
                missingSourceTypes: [.jurisdiction],
                seedGapCategories: [.jurisdiction],
                consentState: .allowed
            )
        )

        XCTAssertEqual(record.operatingMode, .jurisdictionNeeded)
        XCTAssertNil(record.privacySafeRequest)
        XCTAssertFalse(record.canGenerateVisibleStep)
        let need = try XCTUnwrap(record.coverageNeeds.first)
        XCTAssertEqual(need.riskJurisdictionClass, .jurisdictionNeeded)
        XCTAssertEqual(need.privacyClass, .highRiskReviewOnly)
        XCTAssertTrue(need.missingSourceTypes.contains(.jurisdiction))
        let handoff = try XCTUnwrap(record.jurisdictionHandoff)
        XCTAssertEqual(handoff.requestedJurisdictionID, "us_ny")
        XCTAssertTrue(handoff.blockedOutputs.contains("coverage_request"))
        XCTAssertTrue(handoff.handoffRoute.contains("what-ambitions-knows"))
    }

    func testSourceArrivalDetectorMarksCandidateWithoutClaimingResolved() throws {
        let input = makeInput(
            id: "goal.awaiting.source",
            rawGoalText: "Build a safe first travel checklist.",
            family: .travel,
            domain: "travel",
            supportState: .sourceNeeded,
            sourceAuthority: unsupportedSourceAuthority(),
            missingSourceTypes: [.publicSource],
            seedGapCategories: [.starter]
        )
        let signal = CoverageSourceArrivalSignal(
            id: "arrival.travel.starter",
            family: .travel,
            domain: "travel",
            sourceFingerprintID: "source-fingerprint.travel.starter.v1",
            sourceRecordIDs: ["SourceRecord.travel.starter"],
            missingSourceTypes: [.publicSource],
            seedGapCategories: [.starter],
            canSupportCurrentUse: true,
            releaseReceiptIDs: ["ReleaseReceipt.travel.starter"],
            rollbackReceiptIDs: ["RollbackReceipt.travel.starter"],
            observedAt: "2026-06-14T13:40:00Z"
        )

        let record = AnyGoalRuntimeCoverageEngine().evaluate(input, arrivalSignals: [signal])

        XCTAssertEqual(record.operatingMode, .sourceArrived)
        XCTAssertFalse(record.canGenerateVisibleStep)
        let need = try XCTUnwrap(record.coverageNeeds.first)
        XCTAssertEqual(need.lifecycleState, .coverageArrivedCandidate)
        let trace = try XCTUnwrap(record.sourceArrivalTraces.first)
        XCTAssertEqual(trace.state, .candidateForRecheck)
        XCTAssertTrue(trace.requiresLocalRouteRecheck)
        XCTAssertTrue(record.recoveryReceipt.allowedLocalActions.contains("run_local_route_recheck"))
        XCTAssertTrue(record.recoveryReceipt.blockedOutputs.contains("visible_step"))
    }

    func testPrivateDetailsAreRedactedFromLedgerRequestReceiptAndTrace() throws {
        let rawGoal = "Help Jordan manage diagnosis notes at 44 Maple Street before the private hearing."
        let record = AnyGoalRuntimeCoverageEngine().evaluate(
            makeInput(
                id: "goal.sensitive.private",
                rawGoalText: rawGoal,
                family: .sensitivePrivate,
                domain: "private support",
                specificDomain: "personal records",
                supportState: .unsupported,
                sourceAuthority: unsupportedSourceAuthority(),
                consentState: .allowed
            )
        )

        XCTAssertEqual(record.operatingMode, .unsupportedCaptured)
        XCTAssertNil(record.privacySafeRequest)
        let need = try XCTUnwrap(record.coverageNeeds.first)
        XCTAssertEqual(need.privacyClass, .blockedSensitive)
        XCTAssertEqual(need.consentState, .notEligible)
        let output = rendered(record)
        for forbidden in ["Jordan", "diagnosis", "44 Maple", "Maple Street", "private hearing"] {
            XCTAssertFalse(output.localizedCaseInsensitiveContains(forbidden), forbidden)
        }
    }

    func testRecordsAndNeedsAreStableAcrossInputOrder() {
        let firstInput = makeInput(
            id: "goal.b",
            rawGoalText: "Repair the cabinet hinge.",
            family: .repair,
            domain: "repair",
            supportState: .sourceNeeded,
            sourceAuthority: unsupportedSourceAuthority(),
            missingSourceTypes: [.seed],
            seedGapCategories: [.starter]
        )
        let secondInput = makeInput(
            id: "goal.a",
            rawGoalText: "Prepare a course outline.",
            family: .education,
            domain: "education",
            supportState: .sourceNeeded,
            sourceAuthority: unsupportedSourceAuthority(),
            missingSourceTypes: [.review],
            seedGapCategories: [.proof]
        )

        let first = AnyGoalRuntimeCoverageEngine().evaluate([firstInput, secondInput])
        let second = AnyGoalRuntimeCoverageEngine().evaluate([secondInput, firstInput])

        XCTAssertEqual(first.map(\.id), second.map(\.id))
        XCTAssertEqual(first.map(\.goalReferenceID), ["goal.a", "goal.b"])
        XCTAssertEqual(first.flatMap(\.coverageNeeds).map(\.id), second.flatMap(\.coverageNeeds).map(\.id))
    }
}

private extension AnyGoalRuntimeCoverageTests {
    func makeInput(
        id: String = "goal.fixture",
        rawGoalText: String,
        family: AnyGoalFamily,
        domain: String,
        specificDomain: String? = nil,
        supportState: AnyGoalSupportState,
        safetyState: AnyGoalSafetyState = .safe,
        jurisdictionState: AnyGoalJurisdictionState = .notNeeded,
        requestedJurisdictionID: String? = nil,
        sourceAuthority: AnyGoalSourceAuthoritySnapshot,
        missingSourceTypes: [CoverageNeedMissingSourceType] = [.publicSource],
        seedGapCategories: [CoverageNeedSeedGapCategory] = [.goalFamily],
        consentState: CoverageConsentState = .notRequested
    ) -> AnyGoalCoverageInput {
        AnyGoalCoverageInput(
            id: id,
            rawGoalText: rawGoalText,
            family: family,
            domain: domain,
            specificDomain: specificDomain,
            supportState: supportState,
            safetyState: safetyState,
            jurisdictionState: jurisdictionState,
            requestedJurisdictionID: requestedJurisdictionID,
            sourceAuthority: sourceAuthority,
            missingSourceTypes: missingSourceTypes,
            seedGapCategories: seedGapCategories,
            consentState: consentState,
            receiptID: "Receipt.\(id)",
            replayTraceID: "ReplayTrace.\(id)",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/any-goal/\(id)"
        )
    }

    func supportedSourceAuthority(family: AnyGoalFamily) -> AnyGoalSourceAuthoritySnapshot {
        AnyGoalSourceAuthoritySnapshot(
            canSupportCurrentUse: true,
            sourceRecordIDs: ["SourceRecord.\(family.rawValue).approved"],
            sourceFingerprintIDs: ["source-fingerprint.\(family.rawValue).v1"],
            authorityIssueCodes: [],
            freshnessReviewClass: .currentMissing
        )
    }

    func unsupportedSourceAuthority() -> AnyGoalSourceAuthoritySnapshot {
        AnyGoalSourceAuthoritySnapshot(
            canSupportCurrentUse: false,
            sourceRecordIDs: [],
            sourceFingerprintIDs: [],
            authorityIssueCodes: ["source_needed"],
            freshnessReviewClass: .unreviewed
        )
    }

    func rendered(_ record: AnyGoalCoverageRecord) -> String {
        let data = try! JSONEncoder().encode(record)
        return String(data: data, encoding: .utf8)!
    }
}
