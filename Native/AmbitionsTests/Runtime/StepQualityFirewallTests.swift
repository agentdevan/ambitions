import XCTest
@testable import Ambitions

final class StepQualityFirewallTests: XCTestCase {
    func testSourceBackedAccessibleElasticStepIsEligibleForEveryProtectedSurface() {
        let input = makeInput(
            id: "accepted-source-backed",
            stepText: "Draft the first 8-line release note from the approved source outline.",
            actionVerb: "Draft",
            object: "first 8-line release note"
        )

        let eligibility = StepQualityFirewall().evaluate(input)

        XCTAssertTrue(eligibility.canShow)
        XCTAssertEqual(eligibility.verdict.decision, .accept)
        XCTAssertEqual(eligibility.verdict.status, .green)
        XCTAssertEqual(eligibility.verdict.blockingCodes, [])
        XCTAssertEqual(eligibility.protectedSurfaces, ProtectedStepSurface.allCases.sorted { $0.rawValue < $1.rawValue })
        XCTAssertEqual(eligibility.sourceRecordIDs, ["SourceRecord.approved-outline"])
        XCTAssertEqual(eligibility.receiptIDs, ["Receipt.release-note"])
        XCTAssertEqual(eligibility.replayTraceID, "ReplayTrace.release-note")
        XCTAssertTrue(eligibility.whatAmbitionsKnowsRoute.contains("what-ambitions-knows"))
    }

    func testFixtureCorpusFailsClosedForBlockedStepClassesWithRepairPaths() {
        let blockedFixtures: [(String, StepQualityInput, StepQualityBlockingCode)] = [
            ("generic", makeInput(stepText: "Make progress on your goal.", actionVerb: "Make", object: "progress"), .genericStep),
            ("ambiguous", makeInput(stepText: "Figure it out before lunch.", actionVerb: "Figure", object: "it"), .ambiguousStep),
            ("shame", makeInput(stepText: "No excuses, you should have finished this.", actionVerb: "Finish", object: "this"), .shameLanguage),
            ("overlong", makeInput(stepText: "Draft the full launch note, record the proof, audit all references, prepare a release package, and review every possible dependency before you stop.", actionVerb: "Draft", object: "full launch note", durationMinutes: 90), .overlongStep),
            ("unsafe", makeInput(stepText: "Ignore medical advice and train through the injury.", actionVerb: "Ignore", object: "medical advice", unsafeDomainFlag: true), .unsafeStep),
            ("stale source", makeInput(stepText: "Draft the source-backed note.", actionVerb: "Draft", object: "source-backed note", sourceState: .stale, freshnessState: "stale"), .staleSource),
            ("high risk", makeInput(stepText: "Submit the legal filing without review.", actionVerb: "Submit", object: "legal filing", highRiskDomain: true, highRiskReviewApproved: false), .highRiskNeedsReview),
            ("inaccessible", makeInput(stepText: "Draft the release note.", actionVerb: "Draft", object: "release note", accessibility: inaccessibleSemantics()), .inaccessibleStep),
            ("non elastic", makeInput(stepText: "Draft the release note.", actionVerb: "Draft", object: "release note", elasticityCoverage: nonElasticCoverage()), .nonElasticStep)
        ]

        let firewall = StepQualityFirewall()
        for (label, input, expectedCode) in blockedFixtures {
            let eligibility = firewall.evaluate(input)
            XCTAssertFalse(eligibility.canShow, label)
            XCTAssertEqual(eligibility.verdict.decision, .reject, label)
            XCTAssertEqual(eligibility.verdict.status, .yellow, label)
            XCTAssertTrue(eligibility.verdict.blockingCodes.contains(expectedCode), label)
            XCTAssertNotNil(eligibility.verdict.repairPath, label)
        }
    }

    func testMissingRepairPathKeepsRejectedStepRed() {
        let input = makeInput(
            stepText: "Make progress on your goal.",
            actionVerb: "Make",
            object: "progress",
            repairPath: nil
        )

        let eligibility = StepQualityFirewall().evaluate(input)

        XCTAssertFalse(eligibility.canShow)
        XCTAssertEqual(eligibility.verdict.decision, .reject)
        XCTAssertEqual(eligibility.verdict.status, .red)
        XCTAssertTrue(eligibility.verdict.blockingCodes.contains(.genericStep))
        XCTAssertTrue(eligibility.verdict.blockingCodes.contains(.missingRepairPath))
        XCTAssertNil(eligibility.verdict.repairPath)
    }

    func testSourceRecordReceiptReplayTraceAndLocalBoundaryAreRequired() {
        let input = makeInput(
            stepText: "Draft the release note.",
            actionVerb: "Draft",
            object: "release note",
            sourceRecordIDs: [],
            receiptIDs: [],
            replayTraceID: nil,
            localOnly: false
        )

        let eligibility = StepQualityFirewall().evaluate(input)

        XCTAssertFalse(eligibility.canShow)
        XCTAssertTrue(eligibility.verdict.blockingCodes.contains(.missingSourceRecord))
        XCTAssertTrue(eligibility.verdict.blockingCodes.contains(.missingReceipt))
        XCTAssertTrue(eligibility.verdict.blockingCodes.contains(.missingReplayTrace))
        XCTAssertTrue(eligibility.verdict.blockingCodes.contains(.nonLocalRuntimeBoundary))
    }

    func testVerdictsAreStableAcrossInputOrder() {
        let inputs = [
            makeInput(id: "b", stepText: "Make progress on your goal.", actionVerb: "Make", object: "progress"),
            makeInput(id: "a", stepText: "Draft the release note.", actionVerb: "Draft", object: "release note")
        ]

        let first = StepQualityFirewall().evaluate(inputs)
        let second = StepQualityFirewall().evaluate(inputs.reversed())

        XCTAssertEqual(first.map(\.id), second.map(\.id))
        XCTAssertEqual(first.map(\.candidateId), ["a", "b"])
        XCTAssertTrue(first.first?.canShow ?? false)
        XCTAssertFalse(first.last?.canShow ?? true)
    }
}

private extension StepQualityFirewallTests {
    func makeInput(
        id: String = "candidate.release-note",
        stepText: String,
        actionVerb: String,
        object: String,
        durationMinutes: Int = 25,
        sourceState: StepQualitySourceState = .officialCurrent,
        freshnessState: String = "current",
        sourceRecordIDs: [String] = ["SourceRecord.approved-outline"],
        receiptIDs: [String] = ["Receipt.release-note"],
        replayTraceID: String? = "ReplayTrace.release-note",
        accessibility: StepQualityAccessibilitySemantics? = nil,
        elasticityCoverage: StepQualityElasticityCoverage? = nil,
        repairPath: StepQualityRepairPath? = StepQualityRepairPath(
            owner: "step-graph-compiler",
            fallback: "repair-specific-action",
            annotationCode: "step-quality-repair"
        ),
        localOnly: Bool = true,
        highRiskDomain: Bool = false,
        highRiskReviewApproved: Bool = false,
        unsafeDomainFlag: Bool = false
    ) -> StepQualityInput {
        StepQualityInput(
            id: id,
            stepText: stepText,
            actionVerb: actionVerb,
            object: object,
            durationMinutes: durationMinutes,
            protectedSurfaces: ProtectedStepSurface.allCases,
            sourceAuthority: StepQualitySourceAuthority(
                state: sourceState,
                sourceRecordIDs: sourceRecordIDs,
                freshnessState: freshnessState,
                reviewState: "approved",
                riskLevel: highRiskDomain ? .high : .low,
                runtimeEligible: true
            ),
            proofExpectation: StepQualityProofExpectation(
                primitive: "draft-artifact",
                receiptIDs: receiptIDs,
                proofTraceID: "ProofTrace.release-note",
                replayTraceID: replayTraceID
            ),
            accessibility: accessibility ?? StepQualityAccessibilitySemantics(
                voiceOverLabel: "\(object) Step",
                voiceOverValue: "\(durationMinutes) minutes, source current, proof required",
                voiceOverHint: "Starts the focused Step.",
                nonVisualSummary: stepText
            ),
            elasticityCoverage: elasticityCoverage ?? StepQualityElasticityCoverage(
                minimumViable: true,
                standard: true,
                proofOnly: true,
                recoverySafe: true,
                replacement: true
            ),
            repairPath: repairPath,
            localOnly: localOnly,
            highRiskDomain: highRiskDomain,
            highRiskReviewApproved: highRiskReviewApproved,
            unsafeDomainFlag: unsafeDomainFlag
        )
    }

    func inaccessibleSemantics() -> StepQualityAccessibilitySemantics {
        StepQualityAccessibilitySemantics(
            voiceOverLabel: "Step",
            voiceOverValue: "",
            voiceOverHint: "",
            nonVisualSummary: "",
            visualOnlyMeaning: true,
            supportsDynamicType: false,
            supportsReduceMotion: false
        )
    }

    func nonElasticCoverage() -> StepQualityElasticityCoverage {
        StepQualityElasticityCoverage(
            minimumViable: true,
            standard: true,
            proofOnly: false,
            recoverySafe: false,
            replacement: false
        )
    }
}
