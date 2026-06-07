import XCTest
@testable import Ambitions

final class MotionCurrentScreenTests: XCTestCase {
    func testMotionCurrentProjectionContainsRequiredRootChildren() {
        let projection = MotionCurrentProjection.fixture

        XCTAssertEqual(projection.crown.title, "Motion Current")
        XCTAssertFalse(projection.field.title.isEmpty)
        XCTAssertEqual(Set(projection.lanes.map(\.id)), ["proof", "recovery", "reentry"])
        XCTAssertEqual(projection.affordance.items.map(\.label), ["Source", "Proof", "Receipt"])
        XCTAssertEqual(projection.dockActions.map(\.id), ["today", "goals", "time", "trust"])
    }

    func testMotionCurrentFieldKeepsEmptyStateStructured() {
        let field = MotionCurrentProjection.fixture.field

        XCTAssertTrue(field.summary.localizedCaseInsensitiveContains("structured"))
        XCTAssertTrue(field.source.localizedCaseInsensitiveContains("SourceRecord"))
        XCTAssertTrue(field.proof.localizedCaseInsensitiveContains("Proof"))
        XCTAssertTrue(field.receipt.localizedCaseInsensitiveContains("Receipt"))
        XCTAssertTrue(field.control.localizedCaseInsensitiveContains("control"))
    }

    func testMotionLanesStaySemanticWithoutCardStackStateNames() {
        let projection = MotionCurrentProjection.fixture
        let laneTitles = projection.lanes.map(\.title)
        let allCopy = projection.allUserFacingCopy

        XCTAssertEqual(laneTitles, ["Proof lane", "Recovery lane", "Re-entry lane"])
        XCTAssertFalse(allCopy.localizedCaseInsensitiveContains("No Motion " + "Yet"))
        XCTAssertFalse(allCopy.localizedCaseInsensitiveContains("Source " + "Unavailable"))
        XCTAssertFalse(allCopy.localizedCaseInsensitiveContains("seg" + "mented"))
        XCTAssertFalse(allCopy.localizedCaseInsensitiveContains("Pick" + "er"))
    }

    func testMotionCurrentCopyAvoidsForbiddenSurfaceFraming() {
        let allCopy = MotionCurrentProjection.fixture.allUserFacingCopy.lowercased()
        let forbiddenTerms = [
            "ana" + "lytics",
            "dash" + "board",
            "sc" + "ore",
            "str" + "eak",
            "activity" + " feed",
            "X" + "P",
            "product" + "ivity",
            "progress" + " chart"
        ].map { $0.lowercased() }

        for term in forbiddenTerms {
            XCTAssertFalse(
                allCopy.contains(term),
                "Forbidden Motion framing appears in fixture copy: \(term)"
            )
        }
    }

    func testMotionCurrentAffordanceKeepsRuntimeInspectionPathVisible() {
        let projection = MotionCurrentProjection.fixture
        let affordanceCopy = projection.affordance.items
            .map { "\($0.label) \($0.value)" }
            .joined(separator: "\n")

        XCTAssertTrue(affordanceCopy.localizedCaseInsensitiveContains("Source"))
        XCTAssertTrue(affordanceCopy.localizedCaseInsensitiveContains("Proof"))
        XCTAssertTrue(affordanceCopy.localizedCaseInsensitiveContains("Receipt"))
        XCTAssertTrue(projection.crown.chips.contains { $0.title == "Local" })
        XCTAssertTrue(projection.crown.chips.contains { $0.title == "Receipt-aware" })
    }
}

private extension MotionCurrentProjection {
    var allUserFacingCopy: String {
        var parts: [String] = [
            crown.eyebrow,
            crown.title,
            crown.summary,
            field.title,
            field.summary,
            field.source,
            field.proof,
            field.receipt,
            field.control,
            affordance.title
        ]

        parts.append(contentsOf: crown.chips.map(\.title))
        for lane in lanes {
            parts.append(contentsOf: [lane.title, lane.status, lane.summary])
            parts.append(contentsOf: lane.markers.map(\.title))
        }
        for item in affordance.items {
            parts.append(contentsOf: [item.label, item.value])
        }
        parts.append(contentsOf: dockActions.map(\.title))
        return parts.joined(separator: "\n")
    }
}
