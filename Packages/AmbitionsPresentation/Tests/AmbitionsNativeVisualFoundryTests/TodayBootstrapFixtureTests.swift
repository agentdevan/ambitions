import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayBootstrapFixtureTests: XCTestCase {
    func testPreparingForBabyFixtureIsStableSparseAndSynthetic() {
        let fixture = TodayBootstrapFixture.preparingForBaby

        XCTAssertEqual(
            fixture.fixtureID,
            "today-bootstrap/preparing-for-baby/typical/v1"
        )
        XCTAssertTrue(fixture.isSynthetic)
        XCTAssertEqual(fixture.crownTitle, "Today")
        XCTAssertEqual(fixture.startHereEyebrow, "Start Here")
        XCTAssertEqual(fixture.primaryActionTitle, "Open step")
        XCTAssertFalse(fixture.startHereTitle.isEmpty)
        XCTAssertFalse(fixture.currentTruth.isEmpty)
        XCTAssertFalse(fixture.materialConsequence.isEmpty)
        XCTAssertEqual(fixture.timelineTitle, "Today’s Timeline")
        XCTAssertEqual(fixture.timelineEntries.count, 3)
    }

    func testPreparingForBabyFixtureCoversItsOneCoherentLifeContext() {
        let fixture = TodayBootstrapFixture.preparingForBaby
        let copy = ([
            fixture.startHereTitle,
            fixture.currentTruth,
            fixture.materialConsequence
        ] + fixture.timelineEntries.flatMap {
            [$0.title, $0.relationship]
        }).joined(separator: " ").lowercased()

        for expectedIdea in ["baby", "family", "home", "health", "work"] {
            XCTAssertTrue(
                copy.contains(expectedIdea),
                "Fixture must include the \(expectedIdea) relationship"
            )
        }
    }

    func testTimelineEntriesHaveStableUniqueIdentity() {
        let entries = TodayBootstrapFixture.preparingForBaby.timelineEntries

        XCTAssertEqual(Set(entries.map(\.id)).count, entries.count)
        XCTAssertTrue(entries.allSatisfy { !$0.timeLabel.isEmpty })
    }
}
