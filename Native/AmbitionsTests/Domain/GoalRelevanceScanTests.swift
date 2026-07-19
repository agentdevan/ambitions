import XCTest
@testable import Ambitions

final class GoalRelevanceScanTests: XCTestCase {
    func testHighConfidenceMatchIsBlockedFromSilentAttachmentAndKeepsApprovalRequired() {
        let scanner = GoalRelevanceScanner()
        let extraction = CaptureSemanticExtraction.extract(
            from: SmartAttachmentInput(rawText: "Finished first mix proof for Music Goal"),
            routeType: .proofItem,
            selectedCandidate: nil,
            clarification: nil
        )

        let scan = scanner.scan(
            captureID: "capture-goal-music",
            extraction: extraction,
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-music",
                    label: "Music Goal",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.proofItem, .goal, .task]
                )
            ]
        )

        XCTAssertEqual(scan.captureID, "capture-goal-music")
        XCTAssertEqual(scan.scannedGoalIDs, ["goal-music"])
        XCTAssertEqual(scan.highConfidenceMatches.map(\.goalID), ["goal-music"])
        XCTAssertTrue(scan.mediumConfidenceMatches.isEmpty)
        XCTAssertTrue(scan.weakMatches.isEmpty)
        XCTAssertTrue(scan.rejectedMatches.isEmpty)
        XCTAssertTrue(scan.forcedAttachmentBlocked)
        XCTAssertNil(scan.noMatchReason)
        XCTAssertEqual(scan.highConfidenceMatches.first?.requiresUserApproval, true)
        XCTAssertTrue(scan.relevanceReasons["goal-music"]?.contains("proof signal supports a local goal attachment") == true)
    }

    func testMediumConfidenceMatchStaysStandaloneAndSuggestsAttachment() {
        let scanner = GoalRelevanceScanner()
        let extraction = CaptureSemanticExtraction.extract(
            from: SmartAttachmentInput(rawText: "Find NASA contacts on LinkedIn later"),
            routeType: .task,
            selectedCandidate: nil,
            clarification: nil
        )

        let scan = scanner.scan(
            captureID: "capture-nasa",
            extraction: extraction,
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-astronaut",
                    label: "NASA contacts",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem],
                    placementLabel: "Become an Astronaut"
                )
            ]
        )

        XCTAssertEqual(scan.mediumConfidenceMatches.map(\.goalID), ["goal-astronaut"])
        XCTAssertTrue(scan.highConfidenceMatches.isEmpty)
        XCTAssertTrue(scan.weakMatches.isEmpty)
        XCTAssertFalse(scan.forcedAttachmentBlocked)
        XCTAssertNil(scan.noMatchReason)
        XCTAssertEqual(scan.mediumConfidenceMatches.first?.requiresUserApproval, true)
        XCTAssertTrue(scan.mediumConfidenceMatches.first?.reason.localizedCaseInsensitiveContains("Medium confidence match") == true)
    }

    func testWeakAndRejectedMatchesStayConservative() {
        let scanner = GoalRelevanceScanner()
        let extraction = CaptureSemanticExtraction.extract(
            from: SmartAttachmentInput(rawText: "guitar lesson"),
            routeType: .idea,
            selectedCandidate: nil,
            clarification: nil
        )

        let baseline = scanner.scan(
            captureID: "capture-lesson",
            extraction: extraction,
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-guitar",
                    label: "Guitar Goal",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem]
                ),
                SmartAttachmentDestinationCandidate(
                    id: "goal-lesson",
                    label: "Lesson Goal",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem]
                )
            ],
            sourceAtlasMatch: lessonSourceAtlasMatch
        )

        XCTAssertTrue(baseline.weakMatches.isEmpty)
        XCTAssertEqual(baseline.mediumConfidenceMatches.map(\.goalID), ["goal-guitar", "goal-lesson"])
        XCTAssertTrue(baseline.highConfidenceMatches.isEmpty)
        XCTAssertNil(baseline.noMatchReason)

        let corrected = scanner.scan(
            captureID: "capture-lesson",
            extraction: extraction,
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-guitar",
                    label: "Guitar Goal",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem]
                ),
                SmartAttachmentDestinationCandidate(
                    id: "goal-lesson",
                    label: "Lesson Goal",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem]
                )
            ],
            sourceAtlasMatch: lessonSourceAtlasMatch,
            correctionSignal: GoalRelevanceCorrectionSignal(
                preferredGoalIDs: ["goal-lesson"],
                rejectedGoalIDs: ["goal-guitar"],
                note: "User confirmed lesson is the better goal."
            )
        )

        XCTAssertTrue(corrected.mediumConfidenceMatches.isEmpty)
        XCTAssertEqual(corrected.highConfidenceMatches.map(\.goalID), ["goal-lesson"])
        XCTAssertEqual(corrected.rejectedMatches.map(\.goalID), ["goal-guitar"])
        XCTAssertTrue(corrected.weakMatches.isEmpty)
        XCTAssertTrue(corrected.relevanceReasons["goal-lesson"]?.contains("manual correction prefers this goal") == true)
        XCTAssertTrue(corrected.rejectedMatches.first?.reason.localizedCaseInsensitiveContains("User confirmed lesson is the better goal.") == true)
    }

    private var lessonSourceAtlasMatch: SourceAtlasIntentMatch {
        SourceAtlasIntentMatch(
            rawGoalText: "guitar lesson",
            normalizedGoalIntent: "guitar-lesson",
            matchedDomainIDs: [],
            matchedSpecificDomainIDs: [],
            matchedSkillSliceIDs: [],
            matchedRoleIDs: [],
            confidenceBand: .low,
            missingClarifications: [],
            sourceAtlasPackIDs: [],
            rejectedPackIDs: [],
            matchTrace: ["test.fixture.goal-relevance.guitar-lesson"]
        )
    }

    func testNoMatchCapturesStillExplainWhyNothingAttached() {
        let scanner = GoalRelevanceScanner()
        let extraction = CaptureSemanticExtraction.extract(
            from: SmartAttachmentInput(rawText: "quiet journal note"),
            routeType: .idea,
            selectedCandidate: nil,
            clarification: nil
        )

        let scan = scanner.scan(
            captureID: "capture-journal",
            extraction: extraction,
            candidates: []
        )

        XCTAssertTrue(scan.highConfidenceMatches.isEmpty)
        XCTAssertTrue(scan.mediumConfidenceMatches.isEmpty)
        XCTAssertTrue(scan.weakMatches.isEmpty)
        XCTAssertTrue(scan.rejectedMatches.isEmpty)
        XCTAssertEqual(scan.noMatchReason, "No local goals were available to scan.")
        XCTAssertFalse(scan.forcedAttachmentBlocked)
        XCTAssertEqual(scan.explanation, "No local goals were available to scan.")
    }
}
