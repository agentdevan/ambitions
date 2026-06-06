import XCTest
@testable import Ambitions

final class MotionCurrentScreenTests: XCTestCase {
    func testMotionCurrentProjectionContainsBraidedStrands() {
        let projection = MotionCurrentProjection.fixture
        let availableStrands = Set(projection.nodes.map(\.strand))

        XCTAssertTrue(availableStrands.contains(.proof))
        XCTAssertTrue(availableStrands.contains(.recovery))
        XCTAssertTrue(availableStrands.contains(.reentry))
        XCTAssertEqual(
            MotionCurrentStrand.allCases.count,
            3
        )
    }

    func testMotionCurrentProjectionIncludesRequiredStates() {
        let projection = MotionCurrentProjection.fixture
        let kinds = Set(projection.nodes.map(\.kind))
        let required: Set<MotionCurrentNodeKind> = [
            .noMotionYet,
            .sourceUnavailable,
            .lowConfidenceSourceProof,
            .captureObjectPlaced,
            .goalThreadRecommended,
            .timeReflowReview,
            .recovered,
            .stalledReentry,
            .changed,
            .lifeAreaDeveloping,
            .receiptHistoryControl
        ]

        XCTAssertTrue(required.isSubset(of: kinds))
    }

    func testEachMotionCurrentStateExposesContinuityLabels() {
        let projection = MotionCurrentProjection.fixture

        for node in projection.nodes {
            XCTAssertFalse(node.originLabel.isEmpty, "Origin label missing for \(node.kind.rawValue)")
            XCTAssertFalse(node.routeStateLabel.isEmpty, "Route state label missing for \(node.kind.rawValue)")
            XCTAssertFalse(node.sourceLabel.isEmpty, "Source label missing for \(node.kind.rawValue)")
            XCTAssertFalse(node.proofLabel.isEmpty, "Proof label missing for \(node.kind.rawValue)")
            XCTAssertFalse(node.receiptLabel.isEmpty, "Receipt label missing for \(node.kind.rawValue)")
            XCTAssertFalse(node.controlLabel.isEmpty, "Control label missing for \(node.kind.rawValue)")
            XCTAssertTrue(node.nonvisualContinuitySummary.contains(node.originLabel))
            XCTAssertTrue(node.nonvisualContinuitySummary.contains(node.routeStateLabel))
            XCTAssertTrue(node.nonvisualContinuitySummary.contains(node.sourceLabel))
            XCTAssertTrue(node.nonvisualContinuitySummary.contains(node.receiptLabel))
            XCTAssertTrue(node.nonvisualContinuitySummary.contains(node.controlLabel))
        }
    }

    func testMotionCurrentFixtureCoversCrossSurfaceContinuityLoop() {
        let projection = MotionCurrentProjection.fixture
        let allContinuityCopy = projection.nodes
            .map(\.nonvisualContinuitySummary)
            .joined(separator: "\n")
            .lowercased()

        [
            "origin: capture",
            "route: held object to owned surface",
            "route: goal thread to recommended step",
            "origin: today closure",
            "route: time pressure to today preview",
            "route: back-link to today re-entry",
            "source: what ambitions knows",
            "control: reset, pause, disable, or review"
        ].forEach { requiredCopy in
            XCTAssertTrue(
                allContinuityCopy.contains(requiredCopy),
                "Missing cross-surface continuity copy: \(requiredCopy)"
            )
        }
    }

    func testEachNodeHasSinglePrimaryAffordanceAtMost() {
        let projection = MotionCurrentProjection.fixture

        for node in projection.nodes {
            let primaryCount = node.actions.filter(\.isPrimary).count
            XCTAssertLessThanOrEqual(primaryCount, 1, "More than one primary action in \(node.kind.rawValue)")
        }
    }

    func testSelectedStrandExposesOnlyOneVisiblePrimaryAffordance() {
        let projection = MotionCurrentProjection.fixture

        for strand in MotionCurrentStrand.allCases {
            XCTAssertLessThanOrEqual(
                projection.visiblePrimaryActionCount(for: strand),
                1,
                "More than one visible primary action in \(strand.rawValue)"
            )
        }
    }

    func testForbiddenMotionAnalyticsLanguageIsNotUsedInStateCopy() {
        let projection = MotionCurrentProjection.fixture
        let forbiddenTerms = [
            "analytics",
            "metric",
            "dashboard",
            "score",
            "streak",
            "activity feed",
            "guilty",
            "productivity"
        ]

        for node in projection.nodes {
            let text = "\(node.title) \(node.description)".lowercased()
            for term in forbiddenTerms {
                XCTAssertFalse(
                    text.contains(term),
                    "Forbidden term '\(term)' appears in \(node.kind.rawValue)"
                )
            }
        }
    }

    func testReduceMotionAndNormalSummariesContainDifferentTone() {
        let projection = MotionCurrentProjection.fixture

        let normalSummary = projection.groupedSummary(
            for: .proof,
            reduceMotionEnabled: false
        )
        let reducedSummary = projection.groupedSummary(
            for: .proof,
            reduceMotionEnabled: true
        )

        XCTAssertNotEqual(normalSummary, reducedSummary)
        XCTAssertTrue(normalSummary.localizedCaseInsensitiveContains("Focuses one strand"))
        XCTAssertTrue(reducedSummary.localizedCaseInsensitiveContains("Reduce Motion"))
    }
}
