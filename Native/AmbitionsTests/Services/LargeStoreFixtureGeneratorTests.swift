import XCTest
@testable import Ambitions

final class LargeStoreFixtureGeneratorTests: XCTestCase {
    func testGeneratorBuildsDeterministicLocalFixtureStore() {
        let configuration = LargeStoreFixtureConfiguration(
            goalCount: 24,
            capturesPerGoal: 3,
            evidencePerGoal: 2,
            feedbackPerGoal: 1,
            generatedAt: "2026-05-12T17:45:00Z"
        )

        let first = LargeStoreFixtureGenerator().generate(configuration: configuration)
        let second = LargeStoreFixtureGenerator().generate(configuration: configuration)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.summary.goalCount, 24)
        XCTAssertEqual(first.summary.captureCount, 72)
        XCTAssertEqual(first.summary.evidenceCount, 48)
        XCTAssertEqual(first.summary.feedbackCount, 24)
        XCTAssertTrue(first.summary.localOnly)
        XCTAssertEqual(first.goals.map(\.id), (0..<24).map { "large-store-goal-\($0)" })
        XCTAssertEqual(Set(first.captures.compactMap(\.linkedGoalID)), Set(first.goals.map(\.id)))
        XCTAssertTrue(first.evidence.allSatisfy { evidence in
            first.goals.contains(where: { $0.id == evidence.goalID })
        })
    }

    func testGeneratorClampsNegativeConfigurationToEmptyStore() {
        let configuration = LargeStoreFixtureConfiguration(
            goalCount: -1,
            capturesPerGoal: -1,
            evidencePerGoal: -1,
            feedbackPerGoal: -1
        )

        let store = LargeStoreFixtureGenerator().generate(configuration: configuration)

        XCTAssertEqual(store.summary.goalCount, 0)
        XCTAssertEqual(store.summary.captureCount, 0)
        XCTAssertEqual(store.summary.evidenceCount, 0)
        XCTAssertEqual(store.summary.feedbackCount, 0)
        XCTAssertTrue(store.summary.localOnly)
    }
}
