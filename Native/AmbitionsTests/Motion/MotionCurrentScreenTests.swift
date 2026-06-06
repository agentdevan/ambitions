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
            .recovered,
            .stalledReentry,
            .changed,
            .lifeAreaDeveloping
        ]

        XCTAssertTrue(required.isSubset(of: kinds))
    }

    func testEachMotionCurrentStateExposesSourceProofReceiptLabels() {
        let projection = MotionCurrentProjection.fixture

        for node in projection.nodes {
            XCTAssertFalse(node.sourceLabel.isEmpty, "Source label missing for \(node.kind.rawValue)")
            XCTAssertFalse(node.proofLabel.isEmpty, "Proof label missing for \(node.kind.rawValue)")
            XCTAssertFalse(node.receiptLabel.isEmpty, "Receipt label missing for \(node.kind.rawValue)")
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
